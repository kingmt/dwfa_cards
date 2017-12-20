<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
  <xsl:strip-space elements="*"/>

  <xsl:template match="/Loads">
    <Loads>
      <xsl:copy-of select="*" />
    </Loads>
  </xsl:template>

  <xsl:template match="/LOAD">
      <!--
    <xsl:if test="HeaderInformation/RecordType = 00">
    -->
      <Loads>
        <Load>
          <Action>add</Action>
          <BillOfLading><xsl:value-of select="LoadInformation/LoadID" /></BillOfLading>
          <AuxLoadNumber><xsl:value-of select="LoadInformation/LoadTrackingNumber" /></AuxLoadNumber>
          <Carrier>
            <SCAC><xsl:value-of select="HeaderInformation/CarrierCode" /></SCAC>
          </Carrier>
          <xsl:if test="string(LoadInformation/TrailerNumber)">
            <TrailerNumber><xsl:value-of select="LoadInformation/TrailerNumber" /></TrailerNumber>
          </xsl:if>
          <xsl:if test="ReferenceNumberStructure[ReferenceNumberTypeCode='PRO']">
            <PRONumber><xsl:value-of select="ReferenceNumberStructure[ReferenceNumberTypeCode='PRO']/ReferenceNumber" /></PRONumber>
          </xsl:if>
          <Tags>
            <Tag><xsl:value-of select="HeaderInformation/CustomerCode" /></Tag>
            <Tag>BillingCode:<xsl:value-of select="HeaderInformation/BillToCustomerCode" /></Tag>
            <xsl:for-each select="Stop">
              <Tag><xsl:value-of select="ShippingLocationCode" /></Tag>
            </xsl:for-each>
            <xsl:if test="ReferenceNumberStructure[ReferenceNumberTypeCode='SOR']">
              <Tag>SOR:<xsl:value-of select="ReferenceNumberStructure[ReferenceNumberTypeCode='SOR']/ReferenceNumber" /></Tag>
            </xsl:if>
          </Tags>
          <Shipper><xsl:value-of select="HeaderInformation/CustomerCode" /></Shipper>
          <ReferenceNumbers>
            <ReferenceNumber>l11-customerID:<xsl:value-of select="HeaderInformation/CustomerCode" /></ReferenceNumber>
            <ReferenceNumber>BillToCustomerCode:<xsl:value-of select="HeaderInformation/BillToCustomerCode" /></ReferenceNumber>
            <ReferenceNumber><xsl:value-of select="LoadInformation/LoadTrackingNumber" /></ReferenceNumber>
            <ReferenceNumber>QY:<xsl:value-of select="LoadInformation/ServiceCode" /></ReferenceNumber>
            <ReferenceNumber>EquipmentTypeCode:<xsl:value-of select="LoadInformation/EquipmentTypeCode" /></ReferenceNumber>
          </ReferenceNumbers>
          <PickupStops>
            <xsl:for-each select="Stop[StopType='Pick']">
              <PickupStop>
                <xsl:apply-templates select="." />
                <xsl:choose>
                  <xsl:when test="string(AppointmentFromDateTime)">
                    <EarliestPlannedPickupTime><xsl:value-of select="AppointmentFromDateTime" /></EarliestPlannedPickupTime>
                    <LatestPlannedPickupTime><xsl:value-of select="AppointmentToDateTime" /></LatestPlannedPickupTime>
                  </xsl:when>
                  <xsl:when test="string(ComputedArrivalDateTime)">
                    <EarliestPlannedPickupTime><xsl:value-of select="ComputedArrivalDateTime" /></EarliestPlannedPickupTime>
                    <LatestPlannedPickupTime><xsl:value-of select="ComputedDepartureDateTime" /></LatestPlannedPickupTime>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:for-each select="Shipment">
                      <xsl:sort select="PickupFromDateTime" />
                      <xsl:if test="position() = 1">
                        <EarliestPlannedPickupTime><xsl:value-of select="PickupFromDateTime" /></EarliestPlannedPickupTime>
                        <LatestPlannedPickupTime><xsl:value-of select="PickupToDateTime" /></LatestPlannedPickupTime>
                      </xsl:if>
                    </xsl:for-each>
                  </xsl:otherwise>
                </xsl:choose>
              </PickupStop>
            </xsl:for-each>
          </PickupStops>
          <DeliveryStops>
            <xsl:for-each select="Stop[StopType='Drop']">
              <DeliveryStop>
                <xsl:apply-templates select="." />
                <xsl:choose>
                  <xsl:when test="string(AppointmentFromDateTime)">
                    <EarliestAppointmentTime><xsl:value-of select="AppointmentFromDateTime" /></EarliestAppointmentTime>
                    <LatestAppointmentTime><xsl:value-of select="AppointmentToDateTime" /></LatestAppointmentTime>
                  </xsl:when>
                  <xsl:when test="string(ComputedArrivalDateTime)">
                    <EarliestAppointmentTime><xsl:value-of select="ComputedArrivalDateTime" /></EarliestAppointmentTime>
                    <LatestAppointmentTime><xsl:value-of select="ComputedDepartureDateTime" /></LatestAppointmentTime>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:for-each select="Shipment">
                      <xsl:sort select="DeliveryFromDateTime" />
                      <xsl:if test="position() = 1">
                        <EarliestAppointmentTime><xsl:value-of select="DeliveryFromDateTime" /></EarliestAppointmentTime>
                        <LatestAppointmentTime><xsl:value-of select="DeliveryToDateTime" /></LatestAppointmentTime>
                      </xsl:if>
                    </xsl:for-each>
                  </xsl:otherwise>
                </xsl:choose>
              </DeliveryStop>
            </xsl:for-each>
          </DeliveryStops>
        </Load>
      </Loads>
      <!--
    </xsl:if>
    -->
  </xsl:template>

  <xsl:template match="Stop">
    <Name><xsl:value-of select="ShippingLocationName" /></Name>
    <StopId><xsl:value-of select="count(preceding-sibling::Stop) + 1" /></StopId>
    <!--
    <StopId><xsl:value-of select="StopID" /></StopId>
    <Sequence><xsl:value-of select="count(preceding-sibling::*) - 1" /></Sequence>
    <Customer>
      <ShipTo><xsl:value-of select="ShippingLocationCode" /></ShipTo>
    </Customer>
    <xsl:if test="string(SequenceNumber)">
      <StopSequence><xsl:value-of select="SequenceNumber" /></StopSequence>
    </xsl:if>
    -->
    <StreetAddress><xsl:value-of select="Address/Street" /></StreetAddress>
    <City><xsl:value-of select="Address/City" /></City>
    <State><xsl:value-of select="Address/State" /></State>
    <Postal><xsl:value-of select="Address/PostalCode" /></Postal>
    <xsl:choose>
      <xsl:when test="Address/CountryCode='USA'">
        <Country>US</Country>
      </xsl:when>
      <xsl:when test="Address/CountryCode='CAN'">
        <Country>CA</Country>
      </xsl:when>
      <xsl:when test="Address/CountryCode='MEX'">
        <Country>MX</Country>
      </xsl:when>
    </xsl:choose>
    <UnloadTime><xsl:value-of select="LoadingHours" /></UnloadTime>
    <xsl:if test="Shipment/Container[ComponentTypeCode='PALLET']/Item">
      <Pallets>
        <Pallet>
          <Number></Number>
          <Parts>
            <xsl:for-each select="Shipment/Container/Item">
              <Part>
                <ShipperPartNumber><xsl:value-of select="Number" /></ShipperPartNumber>
                <Description><xsl:value-of select="Description" /></Description>
                <Quantity><xsl:value-of select="Quantity" /></Quantity>
                <Weight><xsl:value-of select="NominalWeight" /></Weight>
              </Part>
            </xsl:for-each>
          </Parts>
        </Pallet>
      </Pallets>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
